import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

class FinishEventButton extends StatelessWidget {
  const FinishEventButton({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: BorderSide(color: AppColors.danger.withValues(alpha: 0.42)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.stop_circle_outlined),
        label: const Text('Finalizar evento'),
      ),
    );
  }
}
