import 'package:dexter_assignment/config/app_theme.dart';
import 'package:dexter_assignment/features/home/data/transcript_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranscriptCard extends StatelessWidget {
  final TranscriptEntry entry;
  final bool isLatest;

  const TranscriptCard({super.key, required this.entry, this.isLatest = false});

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, "0");
    final period = dt.hour < 12 ? "AM" : "PM";
    return "$h:$m $period";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: entry.text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Copied to clipboard"),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isLatest)
                  Text(
                    "LATEST",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal.withValues(alpha: 0.8),
                      letterSpacing: 0.8,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Text(
                  _formatTime(entry.capturedAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
