import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hive_word_study_provider.dart';
import '../widgets/flexible_step_progress_indicator.dart';
import '../services/navigation_service.dart';
import '../utils/constants.dart';
import 'final_notes_screen.dart';

class OutsideSourcesScreen extends StatefulWidget {
  const OutsideSourcesScreen({super.key});

  @override
  State<OutsideSourcesScreen> createState() => _OutsideSourcesScreenState();
}

class _OutsideSourcesScreenState extends State<OutsideSourcesScreen> {
  final TextEditingController _sourcesController = TextEditingController();
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    _sourcesController.addListener(_updateCanProceed);
    _loadExistingData();
  }

  void _loadExistingData() {
    final wordStudy = context.read<HiveWordStudyProvider>().currentStudy;
    if (wordStudy?.outsideSources != null) {
      _sourcesController.text = wordStudy!.outsideSources!;
    }
  }

  void _updateCanProceed() {
    setState(() {
      _canProceed = _sourcesController.text.trim().isNotEmpty;
    });
  }

  void _proceedToNextStep() {
    if (_sourcesController.text.trim().isEmpty) return;

    // Update the current study with outside sources
    context.read<HiveWordStudyProvider>().updateOutsideSources(
      _sourcesController.text.trim(),
    );

    // Navigate to final notes screen (Step 5)
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const FinalNotesScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final wordStudy = context.watch<HiveWordStudyProvider>().currentStudy;
    final isCompleted =
        wordStudy != null &&
        context.read<HiveWordStudyProvider>().isStudyCompleted(wordStudy);

    if (wordStudy == null) {
      Navigator.of(context).pop();
      return const Scaffold();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Step 4: Outside Sources - ${wordStudy.selectedWord}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: FlexibleStepProgressIndicator(
              currentStep: 5,
              totalSteps: 6,
              isEditingCompleted: isCompleted,
              onStepTap: (step) =>
                  NavigationService.navigateToStep(context, step),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use outside sources to learn more about "${wordStudy.selectedWord}"',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppConstants.spacing),
                  Text(
                    'Write definitions that you find helpful. How does this grow your understanding of the word in the passage?',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.spacing),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.padding),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suggested Sources:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text('• Bible dictionary'),
                        const Text('• English dictionary'),
                        const Text('• Trustworthy commentaries'),
                        const Text('• NET Bible'),
                        const Text('• BibleHub.com'),
                        const Text('• Other reliable sources'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.padding),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: TextField(
                      controller: _sourcesController,
                      decoration: const InputDecoration(
                        labelText: 'Outside sources and definitions',
                        hintText:
                            'Write down definitions and insights from outside sources that help you understand this word better...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: null,
                      minLines: 8,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                  const SizedBox(height: AppConstants.padding),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canProceed ? _proceedToNextStep : null,
                      child: const Text('Next: Summary & Response'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sourcesController.removeListener(_updateCanProceed);
    _sourcesController.dispose();
    super.dispose();
  }
}
