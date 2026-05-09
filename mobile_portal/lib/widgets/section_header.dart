import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.actionLabel,
    this.onActionTap,
    this.padding = const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space6, AppTheme.space5, AppTheme.space3),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(eyebrow!.toUpperCase(), style: AppTheme.eyebrow()),
                  const SizedBox(height: AppTheme.space1),
                ],
                Text(title, style: AppTheme.h2()),
              ],
            ),
          ),
          if (actionLabel != null && onActionTap != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onActionTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      actionLabel!,
                      style: AppTheme.caption(color: AppTheme.primaryGreen).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryGreen, size: 18),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
