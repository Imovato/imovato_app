import 'package:flutter/material.dart';

class ChatFab extends StatelessWidget {
  const ChatFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.chat_bubble_outline,
    this.backgroundColor,
    this.iconColor = const Color(0xFFD10B58),
    this.tooltip,
    this.heroTag,
    this.badge,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;
  final Object? heroTag;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      heroTag: heroTag,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? scheme.inversePrimary,
      onPressed: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(child: Icon(icon, color: iconColor)),
          if (badge != null && badge! > 0)
            Positioned(
              right: -2,
              top: -2,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: scheme.primary,
                  child: Text(
                    '${badge!}',
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}