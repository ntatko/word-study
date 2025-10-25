import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/hive_word_study_provider.dart';
import '../services/passages_api_service.dart';
import '../utils/constants.dart';
import '../widgets/flexible_step_progress_indicator.dart';
import '../services/navigation_service.dart';
import 'context_screen.dart';

class PassageReadingScreen extends StatefulWidget {
  const PassageReadingScreen({super.key});

  @override
  State<PassageReadingScreen> createState() => _PassageReadingScreenState();
}

class _PassageReadingScreenState extends State<PassageReadingScreen> {
  late WebViewController _webViewController;
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedVersion = AppConstants.bibleVersions.first;
  bool _isLoading = true;
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _wordController.addListener(_updateCanProceed);
  }

  void _updateCanProceed() {
    setState(() {
      _canProceed = _wordController.text.trim().isNotEmpty;
    });
  }

  void _initializeWebView() {
    final wordStudy = context.read<HiveWordStudyProvider>().currentStudy;
    if (wordStudy == null) {
      Navigator.of(context).pop();
      return;
    }

    final url = PassagesApiService.buildBibleGatewayUrl(
      wordStudy.passageReference,
      _selectedVersion,
    );

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _injectCSS();
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _injectCSS() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? '#1E1E1E' : '#FFFFFF';
    final textColor = isDark ? '#FFFFFF' : '#000000';

    final css = isDark
        ? '''
      /* Dark mode - ensure proper contrast */
      body {
        background-color: #1E1E1E !important;
        color: #FFFFFF !important;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif !important;
        line-height: 1.6 !important;
        padding: 20px !important;
      }
      
      /* Force all containers to have dark background */
      div, section, article, main, .passage-content, .passage-text {
        background-color: #1E1E1E !important;
        color: #FFFFFF !important;
      }
      
      /* Force all text elements to be white */
      p, div, span, h1, h2, h3, h4, h5, h6, li, td, th {
        color: #FFFFFF !important;
        background-color: transparent !important;
      }
      
      /* Bible passage content */
      .passage-text {
        font-size: 18px !important;
        line-height: 1.8 !important;
        color: #FFFFFF !important;
        background-color: #1E1E1E !important;
      }
      
      /* Force text color for Bible passage content */
      .passage-content p,
      .passage-content div,
      .passage-content span,
      .passage-text p,
      .passage-text div,
      .passage-text span {
        color: #FFFFFF !important;
        background-color: transparent !important;
      }
      
      /* Hide chapter numbers */
      .chapter-num {
        display: none !important;
      }
      
      /* Ensure proper contrast for links */
      a {
        color: #4A9EFF !important;
        text-decoration: underline !important;
        background-color: transparent !important;
      }
      
      a:hover {
        color: #6BB6FF !important;
      }
      
      /* Override any existing styles with proper contrast */
      * {
        color: #FFFFFF !important;
        background-color: #1E1E1E !important;
      }
      
      /* Ensure text elements don't inherit background */
      p, span, h1, h2, h3, h4, h5, h6, li, td, th {
        background-color: transparent !important;
      }
      
      /* Re-invert images to keep them normal */
      img {
        filter: none !important;
      }
    '''
        : '''
      /* Light mode - normal styling */
      body {
        background-color: $backgroundColor !important;
        color: $textColor !important;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif !important;
        line-height: 1.6 !important;
        padding: 20px !important;
      }
      
      .passage-text {
        font-size: 18px !important;
        line-height: 1.8 !important;
      }
      
      .chapter-num {
        display: none !important;
      }
    ''';

    _webViewController.runJavaScript('''
      var style = document.createElement('style');
      style.innerHTML = `$css`;
      document.head.appendChild(style);
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
        title: Text(wordStudy.passageReference),
        actions: [
          PopupMenuButton<String>(
            onSelected: (version) {
              setState(() {
                _selectedVersion = version;
                _isLoading = true;
              });
              _initializeWebView();
            },
            itemBuilder: (context) => AppConstants.bibleVersions
                .map(
                  (version) =>
                      PopupMenuItem(value: version, child: Text(version)),
                )
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedVersion),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: FlexibleStepProgressIndicator(
              currentStep: 1,
              totalSteps: 6,
              isEditingCompleted: isCompleted,
              onStepTap: (step) =>
                  NavigationService.navigateToStep(context, step),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : WebViewWidget(controller: _webViewController),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _wordController,
                  decoration: const InputDecoration(
                    labelText: 'Selected Word',
                    hintText: 'Enter the word you want to study',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes about the passage',
                    hintText: 'Add any observations or thoughts...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppConstants.padding),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canProceed ? _proceedToNextStep : null,
                    child: const Text('Next: Context'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToNextStep() async {
    if (_wordController.text.trim().isEmpty) return;

    final provider = context.read<HiveWordStudyProvider>();

    // Save the current study to Hive first if it hasn't been saved yet
    await provider.saveCurrentStudy();

    // Update the current study with the selected word and notes
    provider.updateSelectedWord(_wordController.text.trim());
    if (_notesController.text.trim().isNotEmpty) {
      provider.updateNotes(_notesController.text.trim());
    }

    // Refresh the studies list to show the new study
    provider.loadStudies();

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ContextScreen()));
  }

  @override
  void dispose() {
    _wordController.removeListener(_updateCanProceed);
    _wordController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
