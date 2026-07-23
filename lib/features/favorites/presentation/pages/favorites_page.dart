import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../explore/application/explore_controller.dart';
import '../../../search/presentation/widgets/property_card.dart';
import '../../../../shared/widgets/appBar.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const ImovatoAppBar(title: 'Favoritos', showBack: false),
      body: Consumer<ExploreController>(
        builder: (context, controller, _) {
          final favorites = controller.favorites;
          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Icon(Icons.favorite_border,
                          size: 40, color: scheme.primary),
                    ),
                    const SizedBox(height: 20),
                    Text('Nenhum favorito ainda',
                        style: textTheme.titleLarge,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      'Salve os imóveis que combinam com você para encontrá-los aqui.',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final property = favorites[index];
              return InkWell(
                onTap: () => Navigator.pushNamed(
                  context,
                  Routes.propertyDetails,
                  arguments: property,
                ),
                child: PropertyCard(
                  data: property,
                  onToggleFavorite: (isFavorite) =>
                      controller.toggleFavoriteById(property.id, isFavorite),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
