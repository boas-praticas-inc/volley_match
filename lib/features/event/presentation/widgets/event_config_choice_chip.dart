import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

class EventConfigChoiceChip extends StatelessWidget {
  const EventConfigChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textMuted,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: AppColors.surfaceMuted,
      selectedColor: AppColors.primary,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}
