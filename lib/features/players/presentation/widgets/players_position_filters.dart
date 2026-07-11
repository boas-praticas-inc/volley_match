import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

class PlayersPositionFilters extends StatelessWidget {
  const PlayersPositionFilters({
    super.key,
    required this.positions,
    required this.selectedPosition,
    required this.onSelected,
  });

  final List<String> positions;
  final String selectedPosition;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: positions
            .map(
              (position) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(position),
                  selected: position == selectedPosition,
                  onSelected: (_) => onSelected(position),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: position == selectedPosition
                        ? Colors.white
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: AppColors.surfaceMuted,
                  selectedColor: AppColors.primary,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
