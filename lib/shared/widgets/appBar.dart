import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imovato_app/features/explore/application/explore_controller.dart';
import 'profile_menu.dart';

class ExploreSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ExploreSearchAppBar({
    super.key,
    required this.onTapLocation,
    required this.onTapFilter,
    this.showBack,
    this.onBackPressed,
    this.actions,
  });

  final VoidCallback onTapLocation;
  final VoidCallback onTapFilter;
  final bool? showBack;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPopAuto = Navigator.canPop(context);
    final showLeading = showBack ?? canPopAuto;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      automaticallyImplyLeading: false,
      leading: showLeading
          ? BackButton(onPressed: onBackPressed)
          : const SizedBox(width: 48),
      actions: actions ?? [const ProfileMenu(), const SizedBox(width: 8)],
      backgroundColor: scheme.surface,
      elevation: 0,
      title: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.apartment_outlined, color: scheme.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buscar apartamentos',
                    style: textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Consumer<ExploreController>(
                    builder: (context, c, _) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onTapLocation,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: _CidadeLine(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onTapFilter,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.tune, color: scheme.primary),
                  Consumer<ExploreController>(
                    builder: (context, controller, _) {
                      final activeFilters =
                          _countActiveFilters(controller.filters);
                      if (activeFilters == 0) return const SizedBox.shrink();

                      return Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$activeFilters',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha da cidade separada só pra evitar rebuilds maiores.
class _CidadeLine extends StatelessWidget {
  const _CidadeLine();

  @override
  Widget build(BuildContext context) {
    final cidade = context.select<ExploreController, String>((c) => c.cidade);
    final scheme = Theme.of(context).colorScheme;

    return Text(
      cidade,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Função auxiliar para contar filtros avançados ativos
int _countActiveFilters(SearchFilters filters) {
  int count = 0;
  if (filters.priceMin != null) count++;
  if (filters.priceMax != null) count++;
  if (filters.accommodationType != null) count++;
  if (filters.maxOccupancy != null) count++;
  if (filters.allowsPets != null) count++;
  if (filters.allowsChildren != null) count++;
  if (filters.isSharedHosting != null) count++;
  return count;
}
