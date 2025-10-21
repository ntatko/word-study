import 'package:flutter/material.dart';

class FlexibleStepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Function(int)? onStepTap;
  final bool isEditingCompleted; // Whether we're editing a completed study

  const FlexibleStepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onStepTap,
    this.isEditingCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isCompleted = stepNumber < currentStep;
        final isCurrent = stepNumber == currentStep;

        // When editing a completed study, all steps should be clickable
        final isClickable = isEditingCompleted || stepNumber <= currentStep;

        return Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: onStepTap != null && isClickable
                    ? () => onStepTap!(stepNumber)
                    : null,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    border: onStepTap != null && isClickable
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 20,
                          )
                        : Text(
                            stepNumber.toString(),
                            style: TextStyle(
                              color: isCurrent
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              if (index < totalSteps - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
