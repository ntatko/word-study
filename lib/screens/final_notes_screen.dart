import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hive_word_study_provider.dart';
import '../widgets/flexible_step_progress_indicator.dart';
import '../services/navigation_service.dart';
import '../utils/constants.dart';
import 'summary_screen.dart';

class FinalNotesScreen extends StatefulWidget {
  const FinalNotesScreen({super.key});

  @override
  State<FinalNotesScreen> createState() => _FinalNotesScreenState();
}

class _FinalNotesScreenState extends State<FinalNotesScreen> {
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    _summaryController.addListener(_updateCanProceed);
    _responseController.addListener(_updateCanProceed);
    _loadExistingData();
  }

  void _loadExistingData() {
    final wordStudy = context.read<HiveWordStudyProvider>().currentStudy;
    if (wordStudy?.summary != null) {
      _summaryController.text = wordStudy!.summary!;
    }
    if (wordStudy?.personalResponse != null) {
      _responseController.text = wordStudy!.personalResponse!;
    }
  }

  void _updateCanProceed() {
    setState(() {
      _canProceed =
          _summaryController.text.trim().isNotEmpty &&
          _responseController.text.trim().isNotEmpty;
    });
  }

  void _proceedToSummary() {
    if (_summaryController.text.trim().isEmpty ||
        _responseController.text.trim().isEmpty) {
      return;
    }

    // Update the current study with summary and personal response
    context.read<HiveWordStudyProvider>().updateSummary(
      _summaryController.text.trim(),
    );
    context.read<HiveWordStudyProvider>().updatePersonalResponse(
      _responseController.text.trim(),
    );

    // Navigate to summary screen
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SummaryScreen()));
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
        title: Text('Step 5: Summary & Response - ${wordStudy.selectedWord}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: FlexibleStepProgressIndicator(
              currentStep: 6,
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
                    'Summarize and respond to your study of "${wordStudy.selectedWord}"',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppConstants.spacing),

                  // Summary Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1. Summarize',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppConstants.spacing),
                          Text(
                            'What does the word mean in the passage you are studying? How does this meaning relate to who God is and His larger purposes?',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppConstants.padding),
                          TextField(
                            controller: _summaryController,
                            decoration: const InputDecoration(
                              labelText: 'Your summary',
                              hintText:
                                  'Summarize what you\'ve learned about this word and its significance...',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 4,
                            textAlignVertical: TextAlignVertical.top,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.padding),

                  // Personal Response Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2. Respond',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppConstants.spacing),
                          Text(
                            'How might what you have learned impact your relationship with God, your life and relationships, serving the Church, etc.?',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppConstants.padding),
                          TextField(
                            controller: _responseController,
                            decoration: const InputDecoration(
                              labelText: 'Your personal response',
                              hintText:
                                  'How will this study impact your life and relationship with God?...',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 4,
                            textAlignVertical: TextAlignVertical.top,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.padding),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canProceed ? _proceedToSummary : null,
                      child: const Text('Review & Save Study'),
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
    _summaryController.removeListener(_updateCanProceed);
    _responseController.removeListener(_updateCanProceed);
    _summaryController.dispose();
    _responseController.dispose();
    super.dispose();
  }
}
