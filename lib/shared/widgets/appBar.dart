import 'package:flutter/material.dart';

/// Barra superior baseada no componente de 72 px do design system Imovato.
///
/// Mantém somente os elementos essenciais: voltar, título e uma ação opcional.
class ImovatoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ImovatoAppBar({
    required this.title,
    this.showBack,
    this.onBackPressed,
    this.action,
    super.key,
  });

  final String title;
  final bool? showBack;
  final VoidCallback? onBackPressed;
  final Widget? action;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shouldShowBack = showBack ?? Navigator.canPop(context);

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: shouldShowBack ? 64 : 8,
      leading: shouldShowBack
          ? IconButton(
              tooltip: 'Voltar',
              onPressed: onBackPressed ?? () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            )
          : null,
      titleSpacing: shouldShowBack ? 0 : 16,
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        if (action != null) action!,
        const SizedBox(width: 8),
      ],
    );
  }
}
