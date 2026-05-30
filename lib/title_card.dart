import 'package:flutter/material.dart';

class TitleCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? child;
  final EdgeInsetsGeometry? childPadding;
  final VoidCallback? onTap;

  const TitleCard({super.key, required this.title, this.subtitle, this.child, this.childPadding, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Column(
        children: [
          subtitle == null
              ? ListTile(title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis))
              : ListTile(
                  title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
                  visualDensity: VisualDensity.compact,
                ),
          Padding(padding: childPadding ?? const EdgeInsets.symmetric(horizontal: 8), child: child),
        ],
      ),
    );

    if (onTap == null) return card;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}
