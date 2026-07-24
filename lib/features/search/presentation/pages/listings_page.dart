import 'package:flutter/material.dart';
import 'package:imovato_app/app/theme/tokens/imovato_spacing.dart';
import 'package:imovato_app/features/explore/presentation/widgets/localizacao_sheet.dart';
import 'package:imovato_app/shared/models/location_option.dart';
import 'package:provider/provider.dart';
import '../../../../app/router.dart';
import '../../../../shared/widgets/appBar.dart';
import '../../../explore/application/explore_controller.dart';
import '../../../explore/presentation/widgets/filtro_busca_sheet.dart';
import '../widgets/property_card.dart';
import 'package:imovato_app/app/theme/tokens/imovato_radius.dart';

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});
  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  Future<void> _openLocation(BuildContext context) async {
    final controller = context.read<ExploreController>();
    final selected = await showModalBottomSheet<LocationOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocalizacaoSheet(
        initialValue: LocalizacaoSheet.defaultCities.firstWhere(
          (e) => e.label == controller.cidade,
        ),
      ),
    );

    if (selected != null && context.mounted) {
      controller.setCidade(selected);
      Navigator.pushReplacementNamed(context, Routes.buscar);
    }
  }

  Future<void> _openFiltroModal(BuildContext context) async {
    final filters = context.read<ExploreController>().filters;
    final result = await showModalBottomSheet<FiltroBuscaResult>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => FiltroBuscaSheet(
              initial: FiltroBuscaResult(
                priceMin: filters.priceMin,
                priceMax: filters.priceMax,
                accommodationType: filters.accommodationType,
                maxOccupancy: filters.maxOccupancy,
                allowsPets: filters.allowsPets,
                allowsChildren: filters.allowsChildren,
                isSharedHosting: filters.isSharedHosting,
              ),
            ));

    if (result != null && context.mounted) {
      // Verifica se todos os filtros estão vazios (usuário clicou em Limpar)
      final isCleared = result.priceMin == null &&
          result.priceMax == null &&
          result.accommodationType == null &&
          result.maxOccupancy == null &&
          result.allowsPets == null &&
          result.allowsChildren == null &&
          result.isSharedHosting == null;

      // Atualizar os filtros no controller
      final controller = context.read<ExploreController>();

      if (isCleared) {
        // Se limpo, reseta os filtros no controller
        controller.resetFilters();
      } else {
        // Caso contrário, substitui os filtros com os valores selecionados
        final currentCity = controller.filters.city;
        final currentState = controller.filters.state;
        final currentNeighborhood = controller.filters.neighborhood;

        controller.setFilters(SearchFilters(
          priceMin: result.priceMin,
          priceMax: result.priceMax,
          city: currentCity,
          state: currentState,
          neighborhood: currentNeighborhood,
          accommodationType: result.accommodationType,
          maxOccupancy: result.maxOccupancy,
          allowsPets: result.allowsPets,
          allowsChildren: result.allowsChildren,
          isSharedHosting: result.isSharedHosting,
        ));
      }

      // Realizar a busca com os novos filtros
      await controller.searchAccommodations();

      debugPrint(
        'FILTROS -> ${isCleared ? "LIMPO" : "priceMin=${result.priceMin} | priceMax=${result.priceMax} | accommodationType=${result.accommodationType} | maxOccupancy=${result.maxOccupancy} | allowsPets=${result.allowsPets} | allowsChildren=${result.allowsChildren} | isSharedHosting=${result.isSharedHosting}"}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ImovatoAppBar(
        title: 'Buscar imóveis',
        showBack: false,
        action: IconButton(
          tooltip: 'Filtros',
          onPressed: () => _openFiltroModal(context),
          icon: const Icon(Icons.tune_outlined),
        ),
        location: context.watch<ExploreController>().cidade,
        onLocationTap: () => _openLocation(context),
      ),
      body: Consumer<ExploreController>(
        builder: (context, c, _) {
          if (c.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.error != null) {
            return Center(child: Text('Erro: ${c.error}'));
          }

          final items = c.results;

          if (items.isEmpty) {
            return const Center(child: Text('Nenhum imóvel encontrado'));
          }

          return Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(ImovatoSpacing.sm),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: ImovatoSpacing.sm),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(
                        context, Routes.propertyDetails,
                        arguments: item),
                    child: PropertyCard(
                      data: item,
                      onToggleFavorite: (fav) {
                        context
                            .read<ExploreController>()
                            .toggleFavoriteById(item.id, fav);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
