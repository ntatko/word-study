import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hive_word_study_provider.dart';
import '../widgets/flexible_step_progress_indicator.dart';
import '../services/navigation_service.dart';
import '../utils/constants.dart';
import 'cross_references_screen.dart';

class ContextScreen extends StatefulWidget {
  const ContextScreen({super.key});

  @override
  State<ContextScreen> createState() => _ContextScreenState();
}

class _ContextScreenState extends State<ContextScreen> {
  final TextEditingController _contextController = TextEditingController();
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    _contextController.addListener(_updateCanProceed);
    _loadExistingData();
  }

  void _loadExistingData() {
    final wordStudy = context.read<HiveWordStudyProvider>().currentStudy;
    if (wordStudy?.contextThoughts != null) {
      _contextController.text = wordStudy!.contextThoughts!;
    }
  }

  void _updateCanProceed() {
    setState(() {
      _canProceed = _contextController.text.trim().isNotEmpty;
    });
  }

  void _proceedToNextStep() {
    if (_contextController.text.trim().isEmpty) return;

    // Update the current study with context thoughts
    context.read<HiveWordStudyProvider>().updateContextThoughts(
      _contextController.text.trim(),
    );

    // Navigate to cross-references screen (Step 3)
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CrossReferencesScreen()),
    );
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
        title: Text('Step 2: Context - ${wordStudy.selectedWord}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: FlexibleStepProgressIndicator(
              currentStep: 2,
              totalSteps: 5,
              isEditingCompleted: isCompleted,
              onStepTap: (step) =>
                  NavigationService.navigateToStep(context, step),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consider the word "${wordStudy.selectedWord}" in its immediate context',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppConstants.spacing),
                  Text(
                    'What do you think the biblical author intended the word to mean in this passage? Write down your thoughts.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.padding),
                  Expanded(
                    child: TextField(
                      controller: _contextController,
                      decoration: const InputDecoration(
                        labelText: 'Your thoughts on the word in context',
                        hintText:
                            'What does this word mean in this specific passage? What was the author trying to communicate?',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                  const SizedBox(height: AppConstants.padding),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canProceed ? _proceedToNextStep : null,
                      child: const Text('Next: Cross References'),
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
    _contextController.removeListener(_updateCanProceed);
    _contextController.dispose();
    super.dispose();
  }
}
