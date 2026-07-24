import 'package:flutter/material.dart';

/// Destinos exibidos na navegação principal do aplicativo.
enum ImovatoNavigationDestination { home, search, favorites, profile }

/// Navegação inferior alinhada ao design system da Imovato.
///
/// O destino ativo é indicado pela cor primária, sem o fundo em formato de
/// cápsula usado pelo `NavigationBar` padrão do Material 3.
class ImovatoBottomNavigation extends StatelessWidget {
  const ImovatoBottomNavigation({
    required this.currentDestination,
    required this.onDestinationSelected,
    super.key,
  });

  final ImovatoNavigationDestination currentDestination;
  final ValueChanged<ImovatoNavigationDestination> onDestinationSelected;

  static const _items = <_NavigationItem>[
    _NavigationItem(
      destination: ImovatoNavigationDestination.home,
      label: 'Início',
      selectedIcon: Icons.home_outlined,
      icon: Icons.home_outlined,
    ),
    _NavigationItem(
      destination: ImovatoNavigationDestination.search,
      label: 'Buscar',
      selectedIcon: Icons.search,
      icon: Icons.search_outlined,
    ),
    // _NavigationItem(
    //   destination: ImovatoNavigationDestination.favorites,
    //   label: 'Favoritos',
    //   selectedIcon: Icons.favorite,
    //   icon: Icons.favorite_border,
    // ),
    _NavigationItem(
      destination: ImovatoNavigationDestination.profile,
      label: 'Perfil',
      selectedIcon: Icons.person,
      icon: Icons.person_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelLarge;

    return Material(
      color: scheme.surface,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Row(
          children: _items.map((item) {
            final selected = item.destination == currentDestination;
            final color = selected ? scheme.primary : scheme.outline;

            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                label: item.label,
                child: InkWell(
                  onTap: () => onDestinationSelected(item.destination),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? item.selectedIcon : item.icon,
                          color: color,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          style: labelStyle?.copyWith(
                            color: color,
                            fontSize: 12,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.destination,
    required this.label,
    required this.selectedIcon,
    required this.icon,
  });

  final ImovatoNavigationDestination destination;
  final String label;
  final IconData selectedIcon;
  final IconData icon;
}
