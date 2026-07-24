import 'package:flutter/material.dart';

/// Barra superior baseada no componente de 72 px do design system Imovato.
///
/// Mantém somente os elementos essenciais: voltar, título, localização opcional
/// e uma ação opcional.
class ImovatoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ImovatoAppBar({
    required this.title,
    this.showBack,
    this.onBackPressed,
    this.action,
    this.location,
    this.onLocationTap,
    super.key,
  });

  final String title;
  final bool? showBack;
  final VoidCallback? onBackPressed;
  final Widget? action;

  /// Rótulo da localização (ex: cidade selecionada). Quando não-nulo,
  /// exibe uma linha clicável abaixo do título.
  final String? location;

  /// Callback ao tocar na linha de localização.
  final VoidCallback? onLocationTap;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shouldShowBack = showBack ?? Navigator.canPop(context);

    final hasLocation = location != null;

    final titleWidget = hasLocation
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              InkWell(
                onTap: onLocationTap,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        location!,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.expand_more,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          )
        : Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

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
      title: titleWidget,
      actions: [
        if (action != null) action!,
        const SizedBox(width: 8),
      ],
    );
  }
}
