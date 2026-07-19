import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';
import 'package:volley_match/shared/widgets/player_photo_avatar.dart';

import '../../domain/entities/player_entity.dart';

class PlayerListItem extends StatelessWidget {
  const PlayerListItem({super.key, required this.player, required this.onTap});

  final PlayerEntity player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              PlayerPhotoAvatar(
                name: player.name,
                size: 56,
                photoPath: player.photoPath,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      player.position,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(
                        10,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: index < player.skillRating
                                  ? AppColors.primary
                                  : AppColors.borderDisabled,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.textSubtle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
