import 'package:flutter/material.dart';

class EventConfigurationSection extends StatelessWidget {
  const EventConfigurationSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: child,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
