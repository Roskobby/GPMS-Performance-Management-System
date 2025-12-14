import 'package:flutter/material.dart';
import '../models/appraisal_status.dart';

/// Status badge widget to display appraisal status
class StatusBadge extends StatelessWidget {
  final AppraisalStatus status;
  final bool showIcon;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact 
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(status.colorValue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(compact ? 4 : 8),
        border: Border.all(
          color: Color(status.colorValue),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              IconData(status.iconCodePoint, fontFamily: 'MaterialIcons'),
              size: compact ? 14 : 16,
              color: Color(status.colorValue),
            ),
            SizedBox(width: compact ? 4 : 8),
          ],
          Text(
            status.displayText,
            style: TextStyle(
              color: Color(status.colorValue),
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status banner to show at top of screens
class StatusBanner extends StatelessWidget {
  final AppraisalStatus status;
  final String? message;
  final VoidCallback? onEditPressed;

  const StatusBanner({
    super.key,
    required this.status,
    this.message,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show banner for draft status
    if (status == AppraisalStatus.draft) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(status.colorValue),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            IconData(status.iconCodePoint, fontFamily: 'MaterialIcons'),
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.displayText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    message!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (status == AppraisalStatus.finalSubmittedToHR && onEditPressed == null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'READ ONLY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
