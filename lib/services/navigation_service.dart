import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hive_word_study_provider.dart';
import '../screens/passage_reading_screen.dart';
import '../screens/definition_selection_screen.dart';
import '../screens/cross_references_screen.dart';
import '../screens/final_notes_screen.dart';

class NavigationService {
  static void navigateToStep(BuildContext context, int stepNumber) {
    final provider = context.read<HiveWordStudyProvider>();
    final currentStudy = provider.currentStudy;

    if (currentStudy == null) return;

    Widget targetScreen;

    switch (stepNumber) {
      case 1:
        targetScreen = const PassageReadingScreen();
        break;
      case 2:
        targetScreen = const DefinitionSelectionScreen();
        break;
      case 3:
        targetScreen = const CrossReferencesScreen();
        break;
      case 4:
        targetScreen = const FinalNotesScreen();
        break;
      default:
        return; // Invalid step
    }

    // Use pushReplacement to replace the current screen
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => targetScreen));
  }

  static void navigateToNextStep(BuildContext context) {
    final provider = context.read<HiveWordStudyProvider>();
    final currentStudy = provider.currentStudy;

    if (currentStudy == null) return;

    final currentStep = provider.getCurrentStep(currentStudy);
    final nextStep = currentStep + 1;

    if (nextStep <= 4) {
      navigateToStep(context, nextStep);
    }
  }
}
