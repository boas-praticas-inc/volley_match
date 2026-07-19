import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PlayerPhotoAvatar extends StatelessWidget {
  const PlayerPhotoAvatar({
    super.key,
    required this.name,
    required this.size,
    this.photoPath,
    this.backgroundColor = AppColors.primary,
    this.icon,
  });

  final String name;
  final double size;
  final String? photoPath;
  final Color backgroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final effectivePhotoPath = photoPath;
    final hasPhoto =
        effectivePhotoPath != null && effectivePhotoPath.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasPhoto
          ? Image.file(
              File(effectivePhotoPath),
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (context, error, stackTrace) {
                return _AvatarFallback(name: name, size: size, icon: icon);
              },
            )
          : _AvatarFallback(name: name, size: size, icon: icon),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({
    required this.name,
    required this.size,
    required this.icon,
  });

  final String name;
  final double size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = icon;

    if (fallbackIcon != null) {
      return Icon(fallbackIcon, size: size * 0.42, color: Colors.white);
    }

    return Text(
      _initialsFromName(name),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: size * 0.32,
      ),
    );
  }

  String _initialsFromName(String value) {
    final parts = value
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
