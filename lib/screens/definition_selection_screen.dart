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
              currentStep: 3,
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

    // Add EPI (English-Persian Interlinear) predefined definitions first
    cards.addAll(_buildEPIDefinitions(wordStudy?.selectedWord ?? 'Word'));

    // Add API-fetched definitions
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

  List<Widget> _buildEPIDefinitions(String word) {
    // Common biblical word definitions from EPI dictionary
    final epiDefinitions = {
      'love': [
        {
          'definition':
              'Agape: Selfless, sacrificial love that seeks the good of others, especially as demonstrated by God toward humanity.',
          'source': 'EPI - Agape Love',
          'examples': [
            'John 3:16 - "For God so loved the world"',
            '1 Corinthians 13:4-7 - Love is patient and kind',
          ],
        },
        {
          'definition':
              'Phileo: Brotherly love, affection between friends and family members.',
          'source': 'EPI - Phileo Love',
          'examples': [
            'John 11:3 - "Lord, the one you love is sick"',
            'Romans 12:10 - "Be devoted to one another in love"',
          ],
        },
        {
          'definition':
              'Eros: Romantic or passionate love, though rarely used in biblical context.',
          'source': 'EPI - Eros Love',
          'examples': [
            'Song of Songs - Romantic love between husband and wife',
          ],
        },
      ],
      'faith': [
        {
          'definition':
              'Pistis: Trust, confidence, and belief in God and His promises, especially regarding salvation.',
          'source': 'EPI - Pistis Faith',
          'examples': [
            'Hebrews 11:1 - "Faith is confidence in what we hope for"',
            'Romans 1:17 - "The righteous will live by faith"',
          ],
        },
        {
          'definition':
              'Faith as the substance of things hoped for, the evidence of things not seen.',
          'source': 'EPI - Faith Definition',
          'examples': [
            'Hebrews 11:6 - "Without faith it is impossible to please God"',
          ],
        },
      ],
      'grace': [
        {
          'definition':
              'Charis: Unmerited favor, God\'s free gift of salvation and blessing that cannot be earned.',
          'source': 'EPI - Charis Grace',
          'examples': [
            'Ephesians 2:8-9 - "For it is by grace you have been saved"',
            'Romans 3:24 - "Justified freely by his grace"',
          ],
        },
        {
          'definition':
              'Grace as God\'s empowering presence enabling believers to live according to His will.',
          'source': 'EPI - Grace Power',
          'examples': [
            '2 Corinthians 12:9 - "My grace is sufficient for you"',
            'Titus 2:11-12 - "Grace teaches us to say no to ungodliness"',
          ],
        },
      ],
      'peace': [
        {
          'definition':
              'Eirene: Inner tranquility, harmony, and well-being that comes from reconciliation with God.',
          'source': 'EPI - Eirene Peace',
          'examples': [
            'Romans 5:1 - "We have peace with God through our Lord Jesus Christ"',
            'Philippians 4:7 - "Peace of God which transcends understanding"',
          ],
        },
        {
          'definition':
              'Shalom: Complete wholeness, prosperity, and harmony in all relationships.',
          'source': 'EPI - Shalom Peace',
          'examples': [
            'Numbers 6:24-26 - "The Lord bless you and keep you"',
            'Isaiah 9:6 - "Prince of Peace"',
          ],
        },
      ],
      'hope': [
        {
          'definition':
              'Elpis: Confident expectation of future good, especially regarding God\'s promises and eternal life.',
          'source': 'EPI - Elpis Hope',
          'examples': [
            'Romans 15:13 - "May the God of hope fill you with joy and peace"',
            '1 Peter 1:3 - "New birth into a living hope"',
          ],
        },
        {
          'definition':
              'Hope as an anchor for the soul, firm and secure in God\'s faithfulness.',
          'source': 'EPI - Hope Anchor',
          'examples': [
            'Hebrews 6:19 - "We have this hope as an anchor for the soul"',
            'Lamentations 3:21-23 - "Great is your faithfulness"',
          ],
        },
      ],
      'joy': [
        {
          'definition':
              'Chara: Deep, abiding gladness and delight that comes from relationship with God.',
          'source': 'EPI - Chara Joy',
          'examples': [
            'Galatians 5:22 - "Fruit of the Spirit is joy"',
            'Nehemiah 8:10 - "Joy of the Lord is your strength"',
          ],
        },
        {
          'definition':
              'Joy that remains even in trials, rooted in God\'s presence and promises.',
          'source': 'EPI - Joy in Trials',
          'examples': [
            'James 1:2 - "Consider it pure joy when you face trials"',
            '1 Peter 1:8 - "Inexpressible and glorious joy"',
          ],
        },
      ],
    };

    final wordLower = word.toLowerCase();
    final definitions = epiDefinitions[wordLower] ?? [];

    return definitions
        .map(
          (def) => _buildDefinitionCard(
            definition: def['definition'] as String,
            source: def['source'] as String,
            examples: def['examples'] != null
                ? List<String>.from(def['examples'] as List)
                : null,
          ),
        )
        .toList();
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
