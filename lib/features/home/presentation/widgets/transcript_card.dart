import 'package:dexter_assignment/config/app_theme.dart';
import 'package:flutter/material.dart';

class TranscriptCard extends StatelessWidget {
  final String text;
  final bool isLatest;

  const TranscriptCard({super.key, required this.text, this.isLatest = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLatest
              ? AppColors.teal.withValues(alpha: 0.35)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLatest)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "LATEST",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal.withValues(alpha: 0.8),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          Text(
            text.isEmpty ? "..." : text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
