import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'player_photo_avatar.dart';

class TeamPlayerViewData {
  const TeamPlayerViewData({
    required this.name,
    required this.position,
    required this.rotationOrder,
    this.photoPath,
  });

  final String name;
  final String position;
  final int? rotationOrder;
  final String? photoPath;
}

Future<void> showTeamPlayersSheet({
  required BuildContext context,
  required String teamName,
  required List<TeamPlayerViewData> players,
  Color accentColor = AppColors.primary,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _TeamPlayersSheet(
        teamName: teamName,
        players: players,
        accentColor: accentColor,
      );
    },
  );
}

class _TeamPlayersSheet extends StatelessWidget {
  const _TeamPlayersSheet({
    required this.teamName,
    required this.players,
    required this.accentColor,
  });

  final String teamName;
  final List<TeamPlayerViewData> players;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.groups_2_outlined,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teamName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${players.length} jogadores',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (players.isEmpty)
              const _EmptyPlayersMessage()
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.52,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: players.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _TeamPlayerTile(
                      player: players[index],
                      accentColor: accentColor,
                      fallbackOrder: index + 1,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TeamPlayerTile extends StatelessWidget {
  const _TeamPlayerTile({
    required this.player,
    required this.accentColor,
    required this.fallbackOrder,
  });

  final TeamPlayerViewData player;
  final Color accentColor;
  final int fallbackOrder;

  @override
  Widget build(BuildContext context) {
    final order = player.rotationOrder ?? fallbackOrder;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              PlayerPhotoAvatar(
                name: player.name,
                size: 44,
                photoPath: player.photoPath,
                backgroundColor: accentColor,
              ),
              Positioned(
                right: -3,
                bottom: -3,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor),
                  ),
                  child: Center(
                    child: Text(
                      '$order',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              player.position,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlayersMessage extends StatelessWidget {
  const _EmptyPlayersMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        'Nenhum jogador encontrado para este time.',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
