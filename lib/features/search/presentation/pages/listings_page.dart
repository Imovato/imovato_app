import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router.dart';
import '../../../../shared/widgets/appBar.dart';
import '../../../explore/application/explore_controller.dart';
import '../../../explore/presentation/widgets/filtro_busca_sheet.dart';
import '../../../explore/presentation/widgets/localizacao_sheet.dart';
import '../widgets/property_card.dart';

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});
  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  int _filtrosAtivos = 0;
  FiltroBuscaResult? _currentFilters;

  int _countFiltrosAtivos(FiltroBuscaResult f) {
    var c = 0;
    if (f.priceMin != null) c++;
    if (f.priceMax != null) c++;
    if (f.accommodationType != null) c++;
    if (f.maxOccupancy != null) c++;
    if (f.allowsPets != null) c++;
    if (f.allowsChildren != null) c++;
    if (f.isSharedHosting != null) c++;
    return c;
  }

  Future<void> _openFiltroModal(BuildContext context) async {
    final result = await showModalBottomSheet<FiltroBuscaResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FiltroBuscaSheet(initial: _currentFilters),
    );

    if (result != null && context.mounted) {
      // Verifica se todos os filtros estão vazios (usuário clicou em Limpar)
      final isCleared = result.priceMin == null &&
          result.priceMax == null &&
          result.accommodationType == null &&
          result.maxOccupancy == null &&
          result.allowsPets == null &&
          result.allowsChildren == null &&
          result.isSharedHosting == null;

      setState(() {
        _currentFilters = isCleared ? null : result;
        _filtrosAtivos = isCleared ? 0 : _countFiltrosAtivos(result);
      });

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

  Future<void> _openLocalizacaoModal(BuildContext context) async {
    final c = context.read<ExploreController>();
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocalizacaoSheet(initialValue: c.cidade),
    );
    if (selected != null && context.mounted) {
      c.setCidade(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: ExploreSearchAppBar(
          onTapLocation: () => _openLocalizacaoModal(context),
          onTapFilter: () => _openFiltroModal(context)),
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

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return InkWell(
                onTap: () => Navigator.pushNamed(
                    context, Routes.propertyDetails,
                    arguments: item),
                child: PropertyCard(
                  data: item,
                  onToggleFavorite: (fav) {
                    // delegate to controller
                    context
                        .read<ExploreController>()
                        .toggleFavoriteById(item.id, fav);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
