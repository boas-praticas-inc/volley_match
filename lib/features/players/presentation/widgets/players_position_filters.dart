import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

class PlayersPositionFilters extends StatelessWidget {
  const PlayersPositionFilters({super.key});

  static const _filters = [
    ('Todos', true),
    ('Ponteiro', false),
    ('Levantador', false),
    ('Central', false),
    ('Oposto', false),
    ('Libero', false),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter.$1),
                  selected: filter.$2,
                  onSelected: (_) {},
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: filter.$2 ? Colors.white : AppColors.textMuted,
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
