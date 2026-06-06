import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imovato_app/features/explore/application/explore_controller.dart';
import 'profile_menu.dart';

class ExploreSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ExploreSearchAppBar({
    super.key,
    required this.onTapLocation,
    required this.onTapFilter,
    this.showBack,         // null = auto (mostra se puder voltar)
    this.onBackPressed,    // opcional: ação custom no back
    this.actions,          // opcional: ações extras no canto direito
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

    return AppBar(
      automaticallyImplyLeading: false,
      leading: showLeading
        ? BackButton(onPressed: onBackPressed)
        : const SizedBox(width: 48), // Espaço em branco do tamanho do botão
      actions: actions ?? [const ProfileMenu(), const SizedBox(width: 8)],
      backgroundColor: Colors.white,
      elevation: 0,
      title: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.apartment, color: Colors.black54, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buscar apartamentos',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
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
                  const Icon(Icons.tune, color: Colors.black54),
                  Consumer<ExploreController>(
                    builder: (context, controller, _) {
                      final activeFilters = _countActiveFilters(controller.filters);
                      if (activeFilters == 0) return const SizedBox.shrink();

                      return Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
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
    return Text(
      cidade,
      style: const TextStyle(fontSize: 13, color: Colors.black87),
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

