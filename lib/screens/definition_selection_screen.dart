import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hive_word_study_provider.dart';
import '../services/dictionary_api_service.dart';
import '../utils/constants.dart';
import '../widgets/flexible_step_progress_indicator.dart';
import '../services/navigation_service.dart';
import 'cross_references_screen.dart';

class DefinitionSelectionScreen extends StatefulWidget {
  const DefinitionSelectionScreen({super.key});

  @override
  State<DefinitionSelectionScreen> createState() =>
      _DefinitionSelectionScreenState();
}

class _DefinitionSelectionScreenState extends State<DefinitionSelectionScreen> {
  String? _selectedDefinition;
  String? _selectedSource;
  final TextEditingController _customDefinitionController =
      TextEditingController();

  List<DictionaryEntry> _dictionaryEntries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDefinitions();
  }

  Future<void> _fetchDefinitions() async {
    final wordStudy = context.read<HiveWordStudyProvider>().currentStudy;
    if (wordStudy?.selectedWord == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final entries = await DictionaryApiService.fetchDefinitions(
        wordStudy!.selectedWord,
      );
      setState(() {
        _dictionaryEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
      appBar: AppBar(title: Text('Definition: ${wordStudy.selectedWord}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: FlexibleStepProgressIndicator(
              currentStep: 2,
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
                    'Choose the definition that best fits the context of your passage:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.padding),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    _buildErrorWidget()
                  else
                    ..._buildDefinitionCards(),
                  const SizedBox(height: AppConstants.padding),
                  _buildCustomDefinitionCard(),
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
                onPressed: _selectedDefinition == null
                    ? null
                    : _proceedToNextStep,
                child: const Text('Next: Cross References'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDefinitionCards() {
    List<Widget> cards = [];
    final wordStudy = context.read<HiveWordStudyProvider>().currentStudy;

    for (final entry in _dictionaryEntries) {
      for (final sense in entry.senses) {
        cards.add(
          _buildDefinitionCard(
            definition: sense.definition,
            source:
                '${wordStudy?.selectedWord ?? 'Word'} (${entry.partOfSpeech})',
            examples: sense.examples,
          ),
        );
      }
    }

    return cards;
  }

  Widget _buildErrorWidget() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 48,
            ),
            const SizedBox(height: AppConstants.spacing),
            Text(
              'Failed to load definitions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: AppConstants.spacing / 2),
            Text(
              _error ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing),
            ElevatedButton(
              onPressed: _fetchDefinitions,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionCard({
    required String definition,
    required String source,
    List<String>? examples,
  }) {
    final isSelected = _selectedDefinition == definition;

    return Card(
      elevation: isSelected ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDefinition = definition;
            _selectedSource = source;
          });
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      source,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing),
              Text(definition, style: Theme.of(context).textTheme.bodyMedium),
              if (examples != null && examples.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacing / 2),
                Text(
                  'Example: ${examples.first}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDefinitionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Definition',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.spacing),
            TextField(
              controller: _customDefinitionController,
              decoration: const InputDecoration(
                hintText: 'Enter your own definition...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  setState(() {
                    _selectedDefinition = value.trim();
                    _selectedSource = 'Custom';
                  });
                } else {
                  setState(() {
                    _selectedDefinition = null;
                    _selectedSource = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToNextStep() {
    if (_selectedDefinition == null) return;

    // Update the current study with the selected definition
    context.read<HiveWordStudyProvider>().updateDefinition(
      _selectedDefinition!,
      _selectedSource!,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CrossReferencesScreen()),
    );
  }

  @override
  void dispose() {
    _customDefinitionController.dispose();
    super.dispose();
  }
}
