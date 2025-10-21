import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hive_word_study_provider.dart';
import '../providers/passages_provider.dart';
import '../models/passage_model.dart';
import '../models/word_study_model.dart';
import '../widgets/passage_card.dart';
import '../widgets/study_history_card.dart';
import '../utils/constants.dart';
import 'passage_reading_screen.dart';
import 'definition_selection_screen.dart';
import 'cross_references_screen.dart';
import 'summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PassagesProvider>().loadPassages();
      context.read<HiveWordStudyProvider>().loadStudies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PassagesProvider>().loadPassages(forceRefresh: true);
            },
          ),
        ],
      ),
      body: Consumer2<PassagesProvider, HiveWordStudyProvider>(
        builder: (context, passagesProvider, wordStudyProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                passagesProvider.loadPassages(forceRefresh: true),
                wordStudyProvider.loadStudies(),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildManualEntrySection(context),
                  const SizedBox(height: 24),
                  _buildSuggestedPassagesSection(passagesProvider),
                  const SizedBox(height: 24),
                  _buildStudyHistorySection(wordStudyProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildManualEntrySection(BuildContext context) {
    final controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start New Study',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.spacing),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter a Bible passage to study',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppConstants.spacing),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'e.g., John 3:16, Romans 8:28, Psalm 23',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book),
                  ),
                ),
                const SizedBox(height: AppConstants.padding),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        context.read<HiveWordStudyProvider>().startNewStudy(
                          controller.text.trim(),
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PassageReadingScreen(),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Word Study'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedPassagesSection(PassagesProvider passagesProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested Passages',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.spacing),
        if (passagesProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (passagesProvider.error != null)
          _buildErrorWidget(passagesProvider.error!)
        else
          _buildPassagesList(passagesProvider),
      ],
    );
  }

  Widget _buildPassagesList(PassagesProvider passagesProvider) {
    final now = DateTime.now();
    final passages = passagesProvider.passages;

    // Find the index of the passage closest to today's date
    int closestIndex = 0;
    if (passages.isNotEmpty) {
      Duration closestDistance = (passages[0].rollout.difference(now)).abs();
      for (int i = 1; i < passages.length; i++) {
        final distance = (passages[i].rollout.difference(now)).abs();
        if (distance < closestDistance) {
          closestDistance = distance;
          closestIndex = i;
        }
      }
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: ScrollController(
          initialScrollOffset: closestIndex * 256.0, // 240 width + 16 spacing
        ),
        itemCount: passages.length,
        itemBuilder: (context, index) {
          final passage = passages[index];
          return SizedBox(
            width: 240,
            child: Padding(
              padding: const EdgeInsets.only(right: AppConstants.spacing),
              child: PassageCard(
                passage: passage,
                onTap: () => _startWordStudy(context, passage),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudyHistorySection(HiveWordStudyProvider wordStudyProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Studies',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (wordStudyProvider.studies.isNotEmpty)
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full history screen
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing),
        if (wordStudyProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (wordStudyProvider.error != null)
          _buildErrorWidget(wordStudyProvider.error!)
        else if (wordStudyProvider.studies.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: wordStudyProvider.studies.take(5).length,
            itemBuilder: (context, index) {
              final study = wordStudyProvider.studies[index];
              final isPartial = _isPartialStudy(study);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacing),
                child: StudyHistoryCard(
                  study: study,
                  isPartial: isPartial,
                  onTap: () => isPartial
                      ? _resumeStudy(context, study)
                      : _viewStudy(context, study),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildErrorWidget(String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: AppConstants.spacing),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing),
            ElevatedButton(
              onPressed: () {
                context.read<PassagesProvider>().loadPassages(
                  forceRefresh: true,
                );
                context.read<HiveWordStudyProvider>().loadStudies();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.padding * 2),
        child: Column(
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.spacing),
            Text(
              'No studies yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.spacing / 2),
            Text(
              'Start your first word study by selecting a passage above',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _startWordStudy(BuildContext context, Passage passage) {
    context.read<HiveWordStudyProvider>().startNewStudy(
      passage.passage,
      lessonName: passage.lesson,
      studySource: passage.study,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PassageReadingScreen()),
    );
  }

  bool _isPartialStudy(WordStudy study) {
    // A study is considered partial if it doesn't have all required fields
    return study.chosenDefinition == null || study.crossReferences == null;
  }

  void _resumeStudy(BuildContext context, WordStudy study) {
    context.read<HiveWordStudyProvider>().resumeStudy(study);

    // Navigate to the appropriate screen based on what's missing
    if (study.selectedWord.isEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PassageReadingScreen()),
      );
    } else if (study.chosenDefinition == null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const DefinitionSelectionScreen(),
        ),
      );
    } else if (study.crossReferences == null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const CrossReferencesScreen()),
      );
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const SummaryScreen()));
    }
  }

  void _viewStudy(BuildContext context, WordStudy study) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SummaryScreen(study: study, isReadOnly: true),
      ),
    );
  }
}
