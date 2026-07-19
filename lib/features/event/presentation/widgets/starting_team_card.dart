import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

import '../../../team_draw/domain/entities/drawn_team_entity.dart';

class StartingTeamCard extends StatelessWidget {
  const StartingTeamCard({
    super.key,
    required this.team,
    required this.isSelected,
    required this.selectedOrder,
    required this.onTap,
  });

  final DrawnTeamEntity team;
  final bool isSelected;
  final int? selectedOrder;
  final VoidCallback onTap;

  double get averageSkillRating {
    if (team.players.isEmpty) {
      return 0;
    }

    final totalSkillRating = team.players.fold(
      0,
      (total, player) => total + player.skillRating,
    );

    return totalSkillRating / team.players.length;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.successBackground : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.success : AppColors.borderLight,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F101828),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.success : AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isSelected
                    ? Text(
                        '$selectedOrder',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      )
                    : const Icon(
                        Icons.sports_volleyball_outlined,
                        color: AppColors.textMuted,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${team.players.length} jogadores | media ${averageSkillRating.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.success : AppColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
