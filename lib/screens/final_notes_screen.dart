import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hive_word_study_provider.dart';
import '../utils/constants.dart';
import '../widgets/flexible_step_progress_indicator.dart';
import '../services/navigation_service.dart';
import 'summary_screen.dart';

class FinalNotesScreen extends StatefulWidget {
  const FinalNotesScreen({super.key});

  @override
  State<FinalNotesScreen> createState() => _FinalNotesScreenState();
}

class _FinalNotesScreenState extends State<FinalNotesScreen> {
  final TextEditingController _refinedDefinitionController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final wordStudy = context.read<HiveWordStudyProvider>().currentStudy;
    if (wordStudy != null) {
      _refinedDefinitionController.text = wordStudy.refinedDefinition ?? '';
      _notesController.text = wordStudy.notes ?? '';
    }
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
      appBar: AppBar(title: Text('Final Notes: ${wordStudy.selectedWord}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: FlexibleStepProgressIndicator(
              currentStep: 4,
              totalSteps: 4,
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
                    'Review and refine your definition:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing),
                  Text(
                    'Based on your study of "${wordStudy.selectedWord}" in ${wordStudy.passageReference}, would you like to refine your definition or add any final notes?',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.padding),

                  // Current definition display
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Definition:',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppConstants.spacing),
                          Text(
                            wordStudy.chosenDefinition ??
                                'No definition selected',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (wordStudy.definitionSource != null) ...[
                            const SizedBox(height: AppConstants.spacing / 2),
                            Text(
                              'Source: ${wordStudy.definitionSource}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.padding),

                  // Refined definition input
                  Text(
                    'Refined Definition:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing),
                  TextField(
                    controller: _refinedDefinitionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Enter your refined definition based on your study...',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: AppConstants.padding),

                  // Notes input
                  Text(
                    'Additional Notes:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing),
                  TextField(
                    controller: _notesController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText:
                          'Add any additional insights, observations, or notes from your study...',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: AppConstants.padding),

                  // Cross-references summary
                  if (wordStudy.crossReferences != null &&
                      wordStudy.crossReferences!.isNotEmpty) ...[
                    Text(
                      'Cross-References Found:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: wordStudy.crossReferences!.map((reference) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppConstants.spacing / 2,
                              ),
                              child: Text(
                                '• $reference',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.padding),
                  ],
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
                    onPressed: _proceedToSummary,
                    child: const Text('Review & Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToSummary() {
    // Update the current study with refined definition and notes
    if (_refinedDefinitionController.text.trim().isNotEmpty) {
      context.read<HiveWordStudyProvider>().updateRefinedDefinition(
        _refinedDefinitionController.text.trim(),
      );
    }
    if (_notesController.text.trim().isNotEmpty) {
      context.read<HiveWordStudyProvider>().updateNotes(
        _notesController.text.trim(),
      );
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SummaryScreen()));
  }

  @override
  void dispose() {
    _refinedDefinitionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
