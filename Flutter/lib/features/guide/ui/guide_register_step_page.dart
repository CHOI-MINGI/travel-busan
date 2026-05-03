import 'package:flutter/material.dart';

class GuideRegisterStepPage extends StatelessWidget {
  final int currentStep;
  final List<String> stepTitles;

  const GuideRegisterStepPage({
    super.key,
    required this.currentStep,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(stepTitles.length, (index) {
        final bool isActive = index == currentStep;
        final bool isDone = index < currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive || isDone
                            ? const Color(0xFF2F6BFF)
                            : const Color(0xFFE5E7EB),
                      ),
                      child: Icon(
                        isDone ? Icons.check : Icons.edit_note_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stepTitles[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isActive || isDone
                            ? const Color(0xFF2F6BFF)
                            : const Color(0xFF9CA3AF),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (index != stepTitles.length - 1)
                Container(
                  width: 30,
                  height: 2,
                  color: index < currentStep
                      ? const Color(0xFF2F6BFF)
                      : const Color(0xFFE5E7EB),
                ),
            ],
          ),
        );
      }),
    );
  }
}