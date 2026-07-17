import 'dart:io';

import 'package:flutter/material.dart';

import '../../../players/domain/entities/player_entity.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.player,
    required this.size,
    required this.colors,
  });

  final PlayerEntity player;
  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final photoPath = player.photoPath;
    final hasPhoto = photoPath != null && photoPath.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors[player.id % colors.length],
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasPhoto
          ? Image.file(
              File(photoPath),
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (_, _, _) => AvatarFallback(
                player: player,
                size: size,
              ),
            )
          : AvatarFallback(player: player, size: size),
    );
  }
}

class AvatarFallback extends StatelessWidget {
  const AvatarFallback({
    super.key,
    required this.player,
    required this.size,
  });

  final PlayerEntity player;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      _initialsFromName(player.name),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: size * 0.32,
      ),
    );
  }

  String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
