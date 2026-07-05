import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final List<String> labels;

  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.labels = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: i ~/ 2 < currentStep
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
            ),
          );
        }
        final step = i ~/ 2;
        final isCompleted = step < currentStep;
        final isActive = step == currentStep;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 32 : 28,
              height: isActive ? 32 : 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : isActive
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.grey.shade200,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        '${step + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade600,
                        ),
                      ),
              ),
            ),
            if (step < labels.length)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  labels[step],
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive || isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade400,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
