import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hive_word_study_provider.dart';
import '../utils/constants.dart';
import '../widgets/step_progress_indicator.dart';
import 'cross_references_screen.dart';

class BiblicalLanguageScreen extends StatefulWidget {
  const BiblicalLanguageScreen({super.key});

  @override
  State<BiblicalLanguageScreen> createState() => _BiblicalLanguageScreenState();
}

class _BiblicalLanguageScreenState extends State<BiblicalLanguageScreen> {
  final TextEditingController _biblicalWordController = TextEditingController();
  final TextEditingController _biblicalDefinitionController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final wordStudy = context.watch<HiveWordStudyProvider>().currentStudy;

    if (wordStudy == null) {
      return const Scaffold(body: Center(child: Text('No study in progress')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Biblical Language: ${wordStudy.selectedWord}'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(AppConstants.padding),
            child: StepProgressIndicator(currentStep: 3, totalSteps: 5),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter the Greek or Hebrew word and its definition:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.padding),

                  // Placeholder for future API integration
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.padding),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: AppConstants.spacing),
                          Text(
                            'Biblical Language Lookup',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppConstants.spacing / 2),
                          Text(
                            'This feature will be integrated with biblical language APIs in the future.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.padding),

                  TextField(
                    controller: _biblicalWordController,
                    decoration: const InputDecoration(
                      labelText: 'Greek/Hebrew Word',
                      hintText: 'Enter the original language word',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language),
                    ),
                  ),
                  const SizedBox(height: AppConstants.padding),

                  TextField(
                    controller: _biblicalDefinitionController,
                    decoration: const InputDecoration(
                      labelText: 'Biblical Language Definition',
                      hintText: 'Enter the definition in the original language',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: AppConstants.padding),

                  // Placeholder for multiple sources
                  Card(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Future Sources:',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppConstants.spacing / 2),
                          const Text('• Strong\'s Concordance'),
                          const Text('• Thayer\'s Greek Lexicon'),
                          const Text('• Brown-Driver-Briggs Hebrew Lexicon'),
                          const Text('• Blue Letter Bible'),
                        ],
                      ),
                    ),
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _proceedToNextStep,
                child: const Text('Next: Cross References'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToNextStep() {
    // Update the current study with biblical language information
    if (_biblicalWordController.text.trim().isNotEmpty ||
        _biblicalDefinitionController.text.trim().isNotEmpty) {
      context.read<HiveWordStudyProvider>().updateBiblicalLanguage(
        _biblicalWordController.text.trim(),
        _biblicalDefinitionController.text.trim(),
      );
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CrossReferencesScreen()),
    );
  }

  @override
  void dispose() {
    _biblicalWordController.dispose();
    _biblicalDefinitionController.dispose();
    super.dispose();
  }
}
