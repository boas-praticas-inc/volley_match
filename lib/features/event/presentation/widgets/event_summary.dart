import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../domain/entities/event_progress_entity.dart';

class EventSummary extends StatelessWidget {
  const EventSummary({
    super.key,
    required this.progress,
    required this.isRenaming,
    required this.isDeleting,
    required this.onEditName,
    required this.onDelete,
  });

  final EventProgressEntity progress;
  final bool isRenaming;
  final bool isDeleting;
  final VoidCallback onEditName;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  progress.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _EventHeaderActionButton(
                icon: Icons.edit_outlined,
                isLoading: isRenaming,
                onTap: isRenaming || isDeleting ? null : onEditName,
              ),
              const SizedBox(width: 8),
              _EventHeaderActionButton(
                icon: Icons.delete_outline_rounded,
                isLoading: isDeleting,
                onTap: isRenaming || isDeleting ? null : onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  value: '${progress.totalTeams}',
                  label: 'times',
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  value: '${progress.totalPlayers}',
                  label: 'jogadores',
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  value: '${progress.finishedMatches}/${progress.totalMatches}',
                  label: 'partidas',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventHeaderActionButton extends StatelessWidget {
  const _EventHeaderActionButton({
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  final IconData icon;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(11),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
